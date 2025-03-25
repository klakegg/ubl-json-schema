UBL_VERSION = 2.4
UBL_URL = https://docs.oasis-open.org/ubl/os-UBL-$(UBL_VERSION)/mod/UBL-Entities-$(UBL_VERSION).gc

build: target/schema_all.json

clean:
	@rm -rf target example/*.json

convert:
	@for f in $$(ls example/*.yaml); do \
		yq -o=json $$f > $$f.json; \
	done

target/entities.gc:
	@mkdir -p target
	@wget -O target/entities.gc "$(UBL_URL)"

target/entities.json: target/entities.gc bin/jsonify_entities.rb
	@ruby bin/jsonify_entities.rb

target/schema_all.json: target/entities.json bin/generate_all.rb $(shell ls src/definitions/*.json)
	@ruby bin/generate_all.rb