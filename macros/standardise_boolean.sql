{% macro standardise_boolean(col) %}
CASE 
    WHEN LOWER(TRIM({{ col }})) IN ('1','yes','true','y') THEN TRUE 
    WHEN LOWER(TRIM({{ col }})) IN ('0','no','false') THEN FALSE 
END

{% endmacro %}