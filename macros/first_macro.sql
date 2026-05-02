{% macro first_macro(model, column) %}
    select {{ column }}
    from {{ ref(model) }}
    where {{ column }} is null
{% endmacro %}