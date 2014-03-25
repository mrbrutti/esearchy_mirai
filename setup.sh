echo '[*] - Instaling tmux. We will use this to launch the start.sh'
echo '       Feel free to stop and coment this out.'
brew install tmux

echo '[*] - Installing redis'
brew install redis

echo '[*] - Installing mongod'
brew install mongodb

echo '[*] - Installing clamav'
brew install clamav

echo  '[*] - Installing rvm ruby 2.0'
rvm install ruby

echo '[*] - Installing gem dependencies'
bundle install
