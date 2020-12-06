(This directory is callled `proj` but there is also a `proj` command in bin. Distinct for now.)

I have a directory called `~/Projects`. I keep all my projects, personal and professional there.
On multiple computers. I regularly switch between a "work" laptop and a "personal" laptop, but
I often do work stuff on my personal laptop, and I occasionally tweak personal projects
(notably this dotfiles repo) on my work laptop.

I want to keep the dirs "in sync", ideally with the same set of repos and branches
and be able to easily find branches that:

- have no remote counterparts (haven't ever `git push --set-upstream`)
- have commits that aren't pushed
- have untracked changes
- have no remote (rare but local `git init` happens sometimes)

Even nicer:

- have been merged into master
- have been merged into master via github or squash. This shows up as
  `Your branch is based on 'some-remote/my-branch', but the upstream is gone.`

Considerations for my own workflow:

- I try to always rename remotes to github org, so I never have `upstream`,
  it's always `rtimmons`.
- when stacking diffs (PR for branch B depends on PR for branch A) I try to
  name branches like `A--B`.
