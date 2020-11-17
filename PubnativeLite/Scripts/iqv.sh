#!/bin/bash

# Reset and clean local working copy
#git reset --hard
#git clean -d -f

# define string pairs for replacement
declare -a arr=("HyBid,IQV"
                "PNLite,IQVY"
                "PubnativeLite,IQVZ"
                "Hybid,iqvx"
                "hyBid,iqvw"
                "Pubnativenet,Iqzone"
                )

#define file pattern to include in replacement
delim=' -or -iname '
pattern_arr=(\"*.storyboard\" "*.xib" "*.swift" "*.sh" "*.xcworkspacedata" "*.xcscheme" "*.pbxproj" "*.m" "*.h" "*.xib" "*.plist")
printf -v var "%s$delim" "${pattern_arr[@]}" 
pattern="${var%$delim}"

#convert all Info.plist to XML format
find "Info.plist" -exec plutil -convert xml1 {} \;

for i in "${arr[@]}"
do
        OLD=$(echo $i | cut -f1 -d,)
        NEW=$(echo $i | cut -f2 -d,)
        echo "Replace all occurences of $OLD within files to $NEW"
        #find . -type f \( -iname "*.storyboard" -or -iname "*.xib" -or -iname "*.swift" -or -iname "*.sh" -or -iname "*.xcworkspacedata" -or -iname "*.xcscheme" -or -iname "*.pbxproj" -or -iname "*.m" -or -iname "*.h" -or -iname "*.xib" -or -iname "*.plist" \) -print0 | xargs -0 sed -i '' -e 's/'"$OLD/$NEW"'/g'
        find . -type f \( -iname $pattern \) -print0 | xargs -0 sed -i '' -e 's/'"$OLD/$NEW"'/g'

        for x in 1 2 3
        do
                echo "pass $x: Rename files from $OLD to $NEW"
                find . -name "*$OLD*" -exec sh -c 'mv "$1" "$(echo "$1" | sed s/'"$OLD/$NEW"'/)"' _ {} \;
        done
done

#convert all Info.plist back to binary format
find . -type f \( -iname "Info.plist" \)  -exec plutil -convert binary1 {} \;
