KSU_API_VERSION=$(curl -fsSL "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/susfs-main/kernel/Makefile" | \
    grep -m1 "KSU_VERSION_API :=" | awk -F'= ' '{print $2}' | tr -d '[:space:]')

KSU_COMMIT_HASH=$(git rev-parse --short HEAD)
KSU_VERSION_FULL="v$KSU_API_VERSION-$KSU_COMMIT_HASH-@hxmn404"
sed -i '/define get_ksu_version_full/,/endef/d' kernel/Makefile
sed -i '/KSU_VERSION_API :=/d' kernel/Makefile
sed -i '/KSU_VERSION_FULL :=/d' kernel/Makefile

VERSION_DEFINITIONS=$(cat << EOF
define get_ksu_version_full
$KSU_VERSION_FULL
endef

KSU_VERSION_API := $KSU_API_VERSION
KSU_VERSION_FULL := $KSU_VERSION_FULL
EOF
)

awk -v def="$VERSION_DEFINITIONS" '
  /REPO_OWNER :=/ {print; print def; inserted=1; next}
  1
  END {if (!inserted) print def}
' kernel/Makefile > kernel/Makefile.tmp && mv kernel/Makefile.tmp kernel/Makefile

grep -A10 "REPO_OWNER" kernel/Makefile
grep "KSU_VERSION_FULL" kernel/Makefile
