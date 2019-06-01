echo "git push dev.."
git push

echo "deploy static to master.."
hexo deploy --generate
