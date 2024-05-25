# if no command line parameter, show usage and exit
if [ $# -eq 0 ]; then
    echo "Usage: $0 domain ..."
    exit 1
fi

echo "fetch lastest changes from upsteam v2lfay/master and merge to local repo"
# fetch changes from upstream
git fetch v2fly master
# merge to local repo using default commit messsage
git merge v2fly/master --no-edit

# iterate comand line parameters and add them to data file
commit_msg="feat: add domains\n\nAdd domains below to data file"
# Add LF to the file
echo "" >> ./own_data/v2ray
# iterate all parameters except the last one, add them to the data file
for domain in "${@:1:$(($#-1))}"; do
    echo "$domain" >> ./own_data/v2ray
    commit_msg="$commit_msg\n$domain"
done
# Now add the last parameter without a LF
echo -n "${@: -1}" >> ./own_data/v2ray
commit_msg="$commit_msg\n${@: -1}"

# generate data file
go run ./ -datapath ./own_data -outputname v2ray.dat

echo "copy v2ray.dat to remote server"
scp ./v2ray.dat 192.168.1.12:~/v2ray
echo "restart v2ray service on remote server"
echo "input sudo password of remote server"
ssh -t 192.168.1.12 "sudo mv ~/v2ray/v2ray.dat /usr/local/share/v2ray ; sudo systemctl restart v2ray"

echo "Add changes to git repo and push to remote git repo"
# commit changes and push
echo -e $commit_msg > .commit_msg
git add ./own_data/v2ray
git commit -F .commit_msg
rm .commit_msg
git push