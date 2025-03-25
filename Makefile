UBL_VERSION = 2.4
UBL_URL = https://docs.oasis-open.org/ubl/os-UBL-$(UBL_VERSION)/mod/UBL-Entities-$(UBL_VERSION).gc

build: target/example

clean:
	@rm -rf target

deps: .bundle/vendor
.bundle/vendor: Gemfile
	@echo "* Installing Ruby dependencies..."
	@bundle install --path .bundle/vendor

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

target/schemas: target/schemas/Invoice.json
target/schemas/Invoice.json: target/schema_all.json
	@echo "* Generating schemas..."
	@mkdir -p target/schemas
	@ruby src/ruby/generate_schemas.rb

target/example: target/schemas target/example/invoice.json
target/example/invoice.json: target/schemas $(shell ls src/example/*.yaml)
	@echo "* Generating example invoice..."
	@mkdir -p target/example
	@ruby src/ruby/jsonify_examples.rb