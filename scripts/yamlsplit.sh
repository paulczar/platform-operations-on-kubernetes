#!/bin/bash

# Will split a multiline YAML file into individual
# files if created by helm it will name the files
# based on the `# Source:` comment in the YAML.

# Usage: helm template . | yamlsplit <output-dir>
# Usage: . envs/default && helmfile template . | yamlsplit <output-dir>

# Copyright 2019 Paul Czarkowski <pczarkowski@pivotal.io>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


count=0
file_size=0
file_number=0
file_content=()
regex='# Source: (.*)'

OUTDIR=${1}

if [[ "${OUTDIR}" == "" ]]; then
  echo "Usage ./split.sh <output-dir>"
  exit 1
fi

if [[ ! -d "${OUTDIR}" ]]; then
  echo "Usage ./split.sh <output-dir>"
  echo "${OUTDIR} is not a directory"
  exit 1
fi

while IFS= read -r line; do
  let count+=1
  if [[ "${line}" != "---" ]]; then
    if [[ "${line}" =~ $regex ]]; then
      file_name="${BASH_REMATCH[1]//\//_}"
    fi
    file_content+=("${line}")
    let file_size+=1
  else # if [[ "${line}" == "---" ]]
    count=0
    if [[ ${file_size} -eq 0 ]]; then
      continue
    else
      if [[ "${file_name}" == "" ]]; then
        file_name="file-${file_number}.yaml"
      fi
      echo "--> Writing ${OUTDIR}/${file_name}"
      printf "%s\n" "${file_content[@]}" > ${OUTDIR}/${file_name}
    fi
    file_size=0
    file_content=()
    file_name=""
    let file_number+=1
  fi
done
