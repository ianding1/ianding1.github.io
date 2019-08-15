.PHONY: serve build

serve:
	jekyll serve --watch --drafts

build:
	JEKYLL_ENV=production jekyll build
