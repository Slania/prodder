Given 'a "$project" git repository' do |project|
  fixture_repo = File.join(@prodder_root, 'features', 'support', "#{project}.git")
  unless File.directory? fixture_repo
    raise "Cannot initialize repo for project #{project}; expected fixture at: #{fixture_repo}"
  end

  run_simple "mkdir -p repos"
  run_simple "chmod -R a+w repos/#{project}.git" if File.exist? File.join(current_dir, "repos", "#{project}.git")
  remove_dir "repos/#{project}.git"
  run_simple "cp -pR #{fixture_repo} repos/#{project}.git"
end

Given 'I deleted the "$project" git repository' do |project|
  run_simple "rm -rf repos/#{project}.git"
end

Given 'the "$project" git repository does not allow pushing to it' do |project|
  run_simple "chmod -R a-w repos/#{project}.git"
end

Given 'a new commit is already in the "$project" git repository' do |project|
  commit_to_remote project
end

Then 'the new commit should be in the workspace copy of the "$project" repository' do |project|
  check_file_content "prodder-workspace/#{project}/README", 'Also read this!', true
end

Then(/^(\d+) commits? by "([^"]+)" should be in the "([^"]+)" repository$/) do |n, author, project|
  in_workspace(project) do
    authors = `git log --pretty='format:%an'`.split("\n")
    authors.grep(/#{author}/).size.should == Integer(n)
  end
end

Then 'the file "$filename" should now be tracked' do |filename|
  in_current_dir do
    git = Prodder::Git.new(File.expand_path("prodder-workspace/blog"), nil)
    git.should be_tracked(filename)
  end
end

Then 'the latest commit should have changed "$file" to contain "$content"' do |filename, content|
  in_workspace('blog') do
    changed = `git show --name-only HEAD | grep #{filename}`.split("\n")
    changed.should_not be_empty

    diff = `git show HEAD | grep '#{content}'`.split("\n")
    diff.should_not be_empty
  end
end

Then 'the latest commit should not have changed "$filename"' do |filename|
  in_workspace('blog') do
    changed = `git show --name-only HEAD | grep #{filename}`.split("\n")
    changed.should be_empty
  end
end

Then 'the new commit should be in the remote repository' do
  in_current_dir do
    latest = `git --git-dir="./repos/blog.git" log | grep prodder`.split("\n")
    latest.should_not be_empty
  end
end
