build:
	@ruby bin/build.rb

convert:
	@for f in $$(ls example/*.yaml); do \
		yq -o=json $$f > $$f.json; \
	done