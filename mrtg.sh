##### GOOD WORKING MRTG SCRIPT #####
#! /bin/bash/
#### This server runs slow at times and doesn't completely flush tmp files when done so manually removing/creating them for script use #### 
clear 
rm tmp_file2 2>/dev/null 
touch tmp_file2 
rm tmp_file3 2>/dev/null 
touch tmp_file3 
rm cmts.tmp 2>/dev/null 
rm tmp_file1 2>/dev/null 
touch tmp_file1 
rm tmp_file4 2>/dev/null 
touch tmp_file4 
rm mrtglink.txt 2>/dev/null 
touch mrtglink.txt 
rm interfaces.txt 2>/dev/null 
touch interfaces.txt 
rm links.txt 2>/dev/null 
touch links.txt 
rm count.txt 2>/dev/null 
touch count.txt


echo "Enter the hostname of the affected device, such as dtr02hmndla. Note: This script is not compatible with HCR devices."

read host
if [ $host ] ; then
host $host |sed -e 's/.* //' > cmts.tmp
echo 'Device IP Address is'

cat cmts.tmp

echo ""
echo ""
echo ""

curl -s http://enwdcocd-cbo-mrtg-be-01.netops.charter.com/mrtg-device-locator/index.cgi?Input1="$host" > tmp_file1 
cat tmp_file1 | grep -Eo "(http|https)://enwdcocd-[a-zA-Z0-9./?=_-]*" | sort -u > mrtglink.txt
cat tmp_file1 |  sed -e 's/<[^>]*>//g' > tmp_file2 
cat tmp_file2 | sed 's/^[ \t]*//;s/[ \t]*$//' > tmp_file3 
awk 'NF' tmp_file3 > tmp_file4 
cat mrtglink.txt | sed 's/^[ \t]*//;s/[ \t]*$//' >> tmp_file4

echo ""
echo "The main MRTG page with all links is located at http://enwdcocd-cbo-mrtg-01.netops.charter.com/"
echo ""
echo ""

cat tmp_file4

##### BEGIN LINK SCRUB #####

links=$(cat tmp_file1 | grep -ai url | grep -Eo "(http|https)://enwdcocd-[a-zA-Z0-9./?=_-]*" | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//;s/[ \t]*$//')

curl -s $links > links.txt
echo ""
echo ""
echo ""
echo "Enter an additional string to display or narrow down the interface(s) of interest, such as access, cbo, ethernet, video..."
read interface
if [ $interface ] ; then

cat links.txt | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//;s/[ \t]*$//' > interfaces.txt

echo ""
echo ""
echo ""
echo "This is a list of all links on that device that match your query."
echo ""
echo ""
echo ""

##grep --color -aiE $interface interfaces.txt

grep --color -aiw $interface interfaces.txt 
grep -aic $interface interfaces.txt > count.txt
echo ""
echo ""
echo "The number of interfaces that match your query are:"
cat count.txt

echo ""
echo ""
echo ""
echo "The main MRTG page with all links is located at http://enwdcocd-cbo-mrtg-01.netops.charter.com/"
echo ""
echo ""
fi

read -p "Press enter when ready to continue"
##### END LINK SCRUB #####
echo "Now we're going to SSH to the device. If SSH fails you may need to use Telnet. Hit CTL-C to abort."
sleep 3s
ssh $host
fi
