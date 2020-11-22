#!/bin/bash

realpath() {
    OURPWD=$PWD
    cd "$(dirname "$1")" || exit 1
    LINK=$(readlink "$(basename "$1")")
    while [ "$LINK" ]; do
        cd "$(dirname "$LINK")" || exit 1
        LINK=$(readlink "$(basename "$1")")
    done
    REALPATH="$PWD/$(basename "$1")"
    cd "$OURPWD" || exit 1
    echo "$REALPATH"
}

if [ "$1" = "" ]; then
    echo 'Usage: md2html markdown.md'
    exit 1
fi

if [ ! -f "$1" ]; then
    echo 'File not found'
    exit 1
fi

full_input=$(realpath "$1")
full_output="${full_input%.*}.html"

{
cat << EOF
<!DOCTYPE html><html><title>
    $(head -1 "$1"|cut -b2-)
</title><meta http-equiv="Content-Type" content="text/html; charset=UTF8" />
<xmp id="xmp" theme="cerulean" style="display:none;" toc="true">

$(cat "$1")

</xmp>
<script>
    var xmlHtml = document.getElementById("xmp");
    xmlHtml.innerHTML = xmlHtml.innerHTML.replace(/\`\`\`mermaid([\s\S]*?)\`\`\`/g, (a,b) => "<div class='mermaid'>" + b + "</div>");
    xmlHtml.innerHTML = xmlHtml.innerHTML.replace(/\`\`\`text([\s\S]*?)\`\`\`/g, (a,b) => "\`\`\`tex" + b + "\`\`\`");
</script>
<script src="https://cdn.ztx.io/strapdown/strapdown.min.js"></script>
<script src="https://unpkg.com/mermaid@8.4.7/dist/mermaid.min.js"></script>
<script>
    var config = {
        startOnLoad:true,
        flowchart:{
            useMaxWidth:false,
            htmlLabels:true,
            curve:'monotoneX',
        },
        securityLevel:'loose',
    };
    mermaid.initialize(config);
</script>
</html>

EOF
} > "$full_output"
#http://cdn.ztx.io/strapdown/strapdown.min.js%