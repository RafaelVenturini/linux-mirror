alias mkcomp='f() { mkdir -p "$2" && touch "${2:-.}/index.tsx" "${2:-.}/$1.module.css" "${2:-.}/$1.stories.tsx"; }; f'
