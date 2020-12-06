import os
import git
from typing import List


def j(x):
    out = x
    if isinstance(x, list):
        out = ", ".join([str(it) for it in x])
    return out


class GitProject:
    def __init__(self, projects_directory: "ProjectsDirectory", full_path: str):
        self.projects_directory = projects_directory
        self.full_path = full_path
        assert os.path.exists(os.path.join(self.full_path, ".git")), f"Dir {full_path} is not a git repository"
        self.repo = git.Repo(self.full_path)

    @property
    def name(self):
        return os.path.basename(self.full_path)

    def __repr__(self):
        return f"GitProject({self.full_path})"

    @property
    def unsaved_branches(self):
        # TODO: look for upstream ref
        branches = self.repo.branches
        return [b.name for b in branches]


class ProjectsDirectory:
    def __init__(self, path: str):
        if path is None:
            path = os.getcwd()
        self.path = os.path.realpath(path)

    def __getitem__(self, name: str):
        return GitProject(self, os.path.join(self.path, name))

    @property
    def projects(self) -> List[GitProject]:
        print(f"path={self.path}")
        print([p for p in os.listdir(self.path) if os.path.isdir(p)])
        return [GitProject(self, os.path.join(self.path, p))
                for p in os.listdir(self.path)
                if os.path.isdir(os.path.join(self.path, p))]


def main():
    pdir = ProjectsDirectory(os.path.expanduser("~/Projects"))
    for project in pdir.projects:
        print(f"{project.name}: {project.unsaved_branches}")


if __name__ == "__main__":
    main()
