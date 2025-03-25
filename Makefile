UBL_VERSION = 2.4
UBL_URL = https://docs.oasis-open.org/ubl/os-UBL-$(UBL_VERSION)/mod/UBL-Entities-$(UBL_VERSION).gc

build: target/schema_all.json

clean:
	@rm -rf target src/example/*.json

convert:
	@for f in $$(ls src/example/*.yaml); do \
		yq -o=json $$f > $$f.json; \
	done

target/entities.gc:
	@echo "* Downloading UBL $(UBL_VERSION) entities..."
	@mkdir -p target
	@wget -q -O target/entities.gc "$(UBL_URL)"

target/entities.json: target/entities.gc src/ruby/jsonify_entities.rb
	@echo "* Converting entities gc to JSON..."
	@ruby src/ruby/jsonify_entities.rb

target/schema_all.json: target/entities.json src/ruby/generate_all.rb $(shell ls src/definitions/*.json)
	@echo "* Generating 'all' schema..."
	@ruby src/ruby/generate_all.rb