#!/bin/bash

# التحقق من المدخلات
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# النطاق الهدف
domain="$1"

# تشغيل Subfinder
echo "[+] Running Subfinder..."
subfinder -d $domain -o $domain_"subfinder".txt

# تشغيل Amass (الوضع السلبي فقط لاستخراج النطاقات الفرعية)
echo "[+] Running Amass in active mode..."
amass enum -active -d $domain -o $domain_"amass".txt

# تشغيل Assetfinder
echo "[+] Running Assetfinder..."
assetfinder --subs-only $domain > $domain_"assetfinder".txt

# تشغيل Sublist3r
echo "[+] Running Sublist3r..."
sublist3r -d $domain -o $domain_"sublist3r".txt

# دمج النتائج وإزالة التكرار
echo "[+] Merging results and removing duplicates..."
cat $domain_"subfinder".txt $domain_"amass".txt $domain_"assetfinder".txt $domain_"sublist3r".txt | sort -u > combined_subdomains.txt

# التحقق من النطاقات باستخدام MassDNS
echo "[+] Validating subdomains using MassDNS..."
massdns -r resolvers.txt -t A -o S -w valid_subdomains.txt combined_subdomains.txt

# استخراج أسماء النطاقات فقط
echo "[+] Extracting domain names only..."
awk -F ' ' '{print $1}' valid_subdomains.txt > $domain.txt

# عرض النتائج النهائية
echo "=================================="
echo "تم استخراج النطاقات الفرعية الصالحة:"
cat $domain.txt
echo "=================================="

# حفظ النتائج في ملف نهائي
echo "تم حفظ النتائج في: domain_names_only.txt"

