set -e

URL=https://raw.githubusercontent.com/jeromedecoster/bbb/master
FILES=(xaa xab xac)
NAME=cat3.jpg
MD5=7140d0cbc985d292c8c58145a7745534

log() { echo -e "\033[0;4m${1}\033[0m ${@:2}"; }

if [[ -f $NAME ]]
then
    log abort $NAME already exists
    exit
fi

CWD=$(pwd)
TEMP=$(mktemp --directory)

cd $TEMP
for file in "${FILES[@]}"
do
    log download $URL/$file
    if [[ -n $(which curl) ]]
    then
        curl $URL/$file \
            --location \
            --remote-name \
            --progress-bar
    else
        wget $URL/$file \
            --quiet \
            --show-progress
    fi
done

log merge xa*
cat xa* > $NAME

if [[ $(md5sum $NAME | cut -d ' ' -f 1) != $MD5 ]]
then
    log checksum error
    rm --force --recursive $TEMP
    exit
fi

if [[ ! -w $CWD ]]
then
    # if directory not writable
    log warn sudo access is required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && log abort sudo required; exit 1;
    sudo mv $NAME $CWD
else
    mv $NAME $CWD
fi
log complete $NAME successfully created

rm --force --recursive $TEMP
