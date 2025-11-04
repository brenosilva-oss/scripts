#!/bin/bash

#Parameters
PREFIXO=$1

# Lista os schemas baseados no Prefixo
listSchemas() {
        curl --silent -k -X GET --cert /var/ssl/private/schema_registry.crt --key /var/ssl/private/schema_registry.key --cacert /var/ssl/private/ca.crt https://localhost:8081/subjects | sed -e $'s/,/\\\n/g' | grep $PREFIXO
}

# Realiza a mudança da compatibility type para NONE
changeSchemasType() {
    schema_name_list=($(listSchemas))
    schema_size=${#schema_name_list[@]}

    if [[ $schema_size -gt 0 ]]; then
        N=1
        for topic in "${schema_name_list[@]}"; do
            name="${topic:1:-1}"
            echo "Changing schema $name - progress $N of $schema_size"

            curl --silent -k -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data '{"compatibility": "NONE"}' --cert /var/ssl/private/schema_registry.crt --key /var/ssl/private/schema_registry.key --cacert /var/ssl/private/ca.crt "https://localhost:8081/config/$name"

            N=$((N + 1))
        done
        echo "Schemas changed"
    else
        echo "No schema found"
    fi
}

changeSchemasType