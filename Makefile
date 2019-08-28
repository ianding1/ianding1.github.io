.PHONY: serve build

serve:
	jekyll serve --watch --drafts --livereload

build:
	JEKYLL_ENV=production jekyll build
