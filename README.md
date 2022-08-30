# keyer

Record keyboard inputs and format to use document.

There are three formats:
* Plain
* Markdown
* HTML

For example, if there is a given key input `Ctrl + C`,
Each format option generat text as below.

*Plain*
```plaintext
Ctrl + C
```

*Markdown*
```markdown
`Ctrl` + `C`
```

*HTML*
```html
<kbd>Ctrl</kbd> + <kbd>C</kbd>
```


## Limitation
There are some limitations:
* Can not prevent default behavior, like `Alt + F4` or `Win + Z`.
