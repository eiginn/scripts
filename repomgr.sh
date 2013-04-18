#!/bin/bash
#: GistID: 2414d58af553c2ee0b93
#: Title       : repomgr
#: Date Created: Tue Nov 06 2012
#: Last Edit   : Tue Nov 08 2012
#: Author      : Ryan Carter
#: Version     : 0.1
#: Description : Script to manage a deb apt repo using apt-ftparchive
#:             : Used to generate and maintain a "trivial" repository
#: usage       : repomgr [options] | [-i pkg_file_name.deb] | [-r pkg_name]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# You should customize the functions by changing the variables below

echo "yeah don't run this"
exit 1

# Text color variables
txtred='\e[0;31m'       # red
txtgrn='\e[0;32m'       # green
txtylw='\e[0;33m'       # yellow
txtblu='\e[0;34m'       # blue
txtpur='\e[0;35m'       # purple
txtcyn='\e[0;36m'       # cyan
txtwht='\e[0;37m'       # white
bldred='\e[1;31m'       # red    - Bold
bldgrn='\e[1;32m'       # green
bldylw='\e[1;33m'       # yellow
bldblu='\e[1;34m'       # blue
bldpur='\e[1;35m'       # purple
bldcyn='\e[1;36m'       # cyan
bldwht='\e[1;37m'       # white
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst='\e[0m'          # Text reset

# Feedback indicators
info="${bldblu}[${bldylw} ** ${bldblu}]${txtrst}"
request="${bldblu}[${bldylw} ?? ${bldblu}]${txtrst}"
pass="${bldblu}[${bldgrn} ok ${bldblu}]${txtrst}"
warn="${bldblu}[${bldpur} !! ${bldblu}]${txtrst}"
fail="${bldblu}[${bldred} !! ${bldblu}]${txtrst}"

# promt to load external conf if available
if [ -e repo_conf ]; then
    read -e -p 'Load repo_conf file? (y/n): ' answer
    if [[ $answer == 'y' ]]; then
        source repo_conf
    else
        echo 'Using embeded script options'
        sleep 1
    fi
else
    www_dir='/var/www'
    repo_subdir='packages'
    repo_dir="${www_dir}/${repo_subdir}"
    suites=( 'Xstable' 'Xtesting' )
    dist='squeeze'
    arch='amd64'
    use_pools=true
    fqdn='foo.bar.com'
    label='Stable X Repository'
fi

die() {
    echo -e"${fail} $@"
    exit 1
}

usage() {
cat <<-EOF
Repomgr a script to manage deb apt repos
    | -h This help
    | -d location of repo
    | -q Quiet
    | -n 
    | -V Verify Repo
    | -i Insert package
    | -G Generate repo skeleton
EOF
}

genconfs() {
    (
        echo "APT::FTPArchive::Release::Codename \"${dist}\";"
        echo "APT::FTPArchive::Release::Origin \"${fqdn}\";"
        echo "APT::FTPArchive::Release::Components \"main\";"
        echo "APT::FTPArchive::Release::Label \"${label}\";"
        echo "APT::FTPArchive::Release::Architectures \"${arch}\";"
        echo -n "APT::FTPArchive::Release::Suite \"${dist}\";"
    ) > ${www_dir}/apt-release.conf

    (
        echo 'Dir {'
        echo 'ArchiveDir ".";'
        echo 'CacheDir "./.cache";'
        echo '};'
        echo ''
        echo 'Default {'
        echo 'Packages::Compress ". gzip bzip2";'
        echo 'Contents::Compress ". gzip bzip2";'
        echo '};'
        echo ''
        echo ''
        echo 'TreeDefault {'
        echo 'BinCacheDB "packages-$(SECTION)-$(ARCH).db";'
        echo 'Directory "pool/$(SECTION)";'
        echo 'Packages "$(DIST)/$(SECTION)/binary-$(ARCH)/Packages";'
        echo 'Contents "$(DIST)/Contents-$(ARCH)";'
        echo '};'
        echo ''
        echo "Tree \"dists/${dist}\" {"
        echo 'Sections "main";'
        echo "Architectures \"${arch}\";"
        echo -n '}'
    ) > ${www_dir}/apt-ftparchive.conf
}

make_repo() {
    cd "$www_dir"
    mkdir "$repo_subdir"
    mkdir -p "$repo_dir/pool/main"
    mkdir -p "$repo_dir/dists/${dist}/main/binary-${arch}"
    mkdir -p "$repo_dir/.cache"

    gen_confs

    apt-ftparchive generate apt-ftparchive.conf
    apt-ftparchive -c apt-release.conf release dists/${dist} > dists/${dist}/Release
}

insert_pkg() {
    if [ $(file $filename | grep deb 2&1> /dev/null) ]; then
        cp "$filename" "$repo_dir/pool/main"
        sign_release
    else
        die "$filename is not a valid debian package"
    fi
    # need to copy package from location specified to pool and regenerate repo then sign
    echo -e "${pass}Package ${pkgname} inserted successfully"
}

remove_pkg() {
    true
    # remove package file from pool then regenerate and re-sign
}

health_check() {
    true
    # run health check FIXME
    # maybe purge cache and rebuild
    # rm - /var/www/packages/.cache/*
}

sign_release() {
    if true; then
        true
    fi
    gpg --yes -abs -u aptrepo -o dists/${dist}/Release.gpg dists/${dist}/Release
}

OPTERR=0
while getopts ":hGd:n:q" opt; do
    case $opt in
        V)
            true
            ;;
        n)
            true
            ;;
        q)
            true
            ;;
        G)
            # Generate repo skeleton
            if [ ${@#${0}} ]; then
                true
            fi
            true
            ;;
        v)
            true
            ;;
        i)
            filename="${@:-1}"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            usage
            exit 1
            ;;
    esac
done

### ALL ACTIONS TAKEN BELOW HERE ###
echo -e "${info} Info"
echo -e "${pass} Pass"
echo -e "${warn} Warn"
echo -e "${fail} Fail"

# fix any forgotten color escapes
echo -e ${txtrst}
