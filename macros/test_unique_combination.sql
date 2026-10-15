{#- Generic test: the given columns together identify each row (a small stand-in for dbt_utils, so the project needs no packages). -#}
{% test unique_combination(model, columns) %}
select {{ columns | join(', ') }}, count(*) as n
from {{ model }}
group by {{ columns | join(', ') }}
having count(*) > 1
{% endtest %}
