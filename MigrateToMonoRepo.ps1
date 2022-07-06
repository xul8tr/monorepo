### Need to install: python3 AND git-filter-repo ###
### https://github.com/newren/git-filter-repo ###
### Update the first line of git-filter-repo to say "python" if the command "python3" doesn't exist in cmd ###
### Copy git-filter-repo to the path returned from: git --exec-path ###

### Azure DevOps Url schema ###
$BaseRepoUrl = "https://{DevOpsURL}/{Project}/_git";

### Repo should already exist in git ###
$MonoRepoName = '{MonoRepoName}';

### Path to your git repos folder, ig: C:\Code\Repos ###
$BasePath = '{GitRepoDir}';

$BaseRepoPath = "$BasePath\$MonoRepoName";
$BaseReposTempPath = "$BasePath\MonoMigrations";

Set-Location $BasePath;

if (Test-Path $BaseReposTempPath) { 
    Remove-Item $BaseReposTempPath -Force  -Recurse;
}

New-Item $BaseReposTempPath -ItemType Directory;

if (Test-Path $BaseRepoPath) { 
    Remove-Item $BaseRepoPath -Force -Recurse;
}

git clone "$BaseRepoUrl/$MonoRepoName";
Set-Location $BaseReposTempPath;
git init;
git commit --allow-empty -n -m "Initial commit.";

$Repos = @(
    [PSCustomObject]@{Name='{Repo1}'; Branch = '{Branch}'}
    [PSCustomObject]@{Name='{Repo2}'; Branch = 'master'},
);

foreach ($Repo in $Repos) {
    $RepoName = $Repo.Name;
    $RepoBranch = $Repo.Branch;
    $RepoPath = "$BaseReposTempPath\$RepoName";
    New-Item $RepoPath -ItemType Directory;
    Set-Location $RepoPath;
    git init;
    git remote add "$RepoName" "$BaseRepoUrl/$RepoName";
    git fetch "$RepoName";
    git merge --allow-unrelated-histories "$RepoName/$RepoBranch";
    
    ### Put in {MonoRepo}\Repos\{Repo} sub folder ###
    #git filter-repo --to-subdirectory-filter "Repos/$RepoName" --force;
    
    ### Put in {MonoRepo}\{Repo} sub folder ###
    git filter-repo --to-subdirectory-filter "$RepoName" --force;
    
    git commit --allow-empty -n -m "Initial commit.";
    Set-Location $BaseRepoPath;
    git remote add "$RepoName" "$RepoPath";
    git fetch "$RepoName";
    git merge --allow-unrelated-histories "$RepoName/master";
    git commit -m "Added $RepoName repo";
    git remote rm "$RepoName";
}

### Garbage collection for git ###
git gc;

### Verify first before you push ###
#git push;
