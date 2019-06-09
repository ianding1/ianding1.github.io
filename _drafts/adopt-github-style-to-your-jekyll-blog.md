---
layout: post
title: "Adopt GitHub Style to Your Jekyll Blog"
date: 2019-06-06
tags: [web]
banner_image: jekyll-banner.jpg
---

I have spent a lot of time trying to find a Jekyll theme that is both elegant
and readable. But unfortunately, most Jekyll themes is just so unreadable that
your attention is easily distracted away from the content.

I don't mean that they are not good-looking. To the contrary, some themes look
quite modern, showing a distinguished taste of the blogger. However, it is not
that good if the style overwhelms the content, especially for a technology blog,
where any distraction seems to be a sin.

Fortunately, I noticed that GitHub renders Markdown files in a very readable
style. It is so natural that it takes no effort for the reader to pay all the
attention to the content rather than the style. So I decided to migrate the
GitHub style to my blog, which you have already been reading.

**In a word, what we need is a GitHub-flavored markdown renderer and a GitHub
CSS.** I find the following posts and code very helpful and I would
recommend reading them for further detail.

- [Configuring
  Redcarpet](https://george-hawkins.github.io/basic-gfm-jekyll/redcarpet-extensions.html):
  How to use Redcarpet as your markdown renderer. The post itself is an
  outstanding example of what your blog will be like after adopting the GitHub
  style.
- [vmg/redcarpet](https://github.com/vmg/redcarpet/): The markdown renderer that
  GitHub uses.
- [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css):
  The minimal GitHub CSS.
- [jwarby/jekyll-pygments-themes](https://github.com/jwarby/jekyll-pygments-themes):
  The code highlighting CSS for GitHub and many other styles.

Here is a step-by-step tutorial of adopting the GitHub style to your blog:

In your `_config.yml`, replace the markdown renderer with Redcarpet:

```yaml
redcarpet:
    extensions: ["no_intra_emphasis", "tables", "autolink", "strikethrough", "with_toc_data"]
```

If you didn't install Redcarpet in your system, then you should install it
first.

Download the [GitHub Markdown
CSS](https://github.com/sindresorhus/github-markdown-css/blob/gh-pages/github-markdown.css)
to your `_sass/` directory, and rename it to `_github-markdown.scss`.

Download the [GitHub Pygment
CSS](https://github.com/jwarby/jekyll-pygments-themes/blob/master/github.css) to
your `_sass/` directory, and rename it to `_github.scss`.

Edit the SCSS file that imports other SCSS files. It is `css/main.scss` in my
blog, but it can be different in your blog. Add the two new files into it
(without the leading underscore and the extension name, just `github-markdown`
and `github`).

The result should look like this:

```scss
@import 
    // The original imports...
    "github-markdown",
    "github"
;
```

The last step is to edit the template files and add `markdown-body` to the class
attribute of the `<div>` for the post content. My post template file is
`_layout/post.html`.

Here is an example of the modified template:

{% raw %}
```html
<div class="entry-content markdown-body">
    {{content}}
</div><!-- .entry-content -->
```
{% endraw %}

Congrats! You have made your blog much more readable!
