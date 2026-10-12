-- RPCs usadas pelo app para gravar pessoas e alergias numa só transação.
-- security invoker: as políticas RLS e os triggers continuam valendo.

-- Substitui todas as alergias de uma pessoa (titular ou membro).
-- p_allergies: [{"allergen_code": "amendoim", "severity": "grave"}, ...]
create function public.set_person_allergens(
  p_person_type public.person_type,
  p_person_id uuid,
  p_allergies jsonb
)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not public.owns_person(p_person_type, p_person_id) then
    raise exception 'Pessoa não encontrada.' using errcode = '42501';
  end if;

  delete from public.person_allergens
  where person_type = p_person_type and person_id = p_person_id;

  insert into public.person_allergens (person_type, person_id, allergen_code, severity)
  select
    p_person_type,
    p_person_id,
    item ->> 'allergen_code',
    coalesce((item ->> 'severity')::public.allergy_severity, 'leve')
  from jsonb_array_elements(coalesce(p_allergies, '[]'::jsonb)) as item;
end;
$$;

-- Cria (p_id nulo) ou atualiza um membro do grupo com as alergias.
-- O limite do plano free vem do trigger enforce_free_member_limit
-- (errcode P0001, hint 'free_member_limit').
create function public.save_group_member(
  p_id uuid,
  p_name text,
  p_birth_date date,
  p_sex public.sex_type,
  p_allergies jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  member_id uuid;
begin
  if p_id is null then
    insert into public.group_members (name, birth_date, sex)
    values (p_name, p_birth_date, p_sex)
    returning id into member_id;
  else
    update public.group_members
    set name = p_name, birth_date = p_birth_date, sex = p_sex
    where id = p_id
    returning id into member_id;

    if member_id is null then
      raise exception 'Membro não encontrado.' using errcode = 'P0002';
    end if;
  end if;

  perform public.set_person_allergens('member', member_id, p_allergies);
  return member_id;
end;
$$;

-- Onboarding: grava o consentimento LGPD e as alergias do titular juntos.
-- Se as alergias falharem, o consentimento também é desfeito: um perfil
-- "pronto" sem alergias faria o app mostrar SEGURO para essa pessoa.
create function public.complete_onboarding(p_allergies jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  update public.profiles
  set health_consent_at = coalesce(health_consent_at, now())
  where id = auth.uid();

  if not found then
    raise exception 'Perfil não encontrado.' using errcode = 'P0002';
  end if;

  perform public.set_person_allergens('profile', auth.uid(), p_allergies);
end;
$$;

revoke execute on function public.complete_onboarding(jsonb) from public, anon;
grant execute on function public.complete_onboarding(jsonb) to authenticated;

revoke execute on function public.set_person_allergens(public.person_type, uuid, jsonb)
  from public, anon;
revoke execute on function public.save_group_member(uuid, text, date, public.sex_type, jsonb)
  from public, anon;
grant execute on function public.set_person_allergens(public.person_type, uuid, jsonb)
  to authenticated;
grant execute on function public.save_group_member(uuid, text, date, public.sex_type, jsonb)
  to authenticated;
