#!/bin/bash

find . -name "*.swift" -type f -print0 | while IFS= read -r -d '' file; do
  perl -i -ne 'print unless /^\s*import\s+Moya\b/' "$file"
done

echo "✅ All 'import Moya' lines deleted using Perl."