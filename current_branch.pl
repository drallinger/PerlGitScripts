#!/usr/bin/perl
use strict;
use warnings;
use feature "say";
use autodie;
use Term::ANSIColor;
use Git::Repository;
my @branches = Git::Repository->new->run("branch");
my $current_branch;
for my $branch(@branches){
    if($branch =~ m#^\*\s(.+)$#){
        $current_branch = $1;
        last;
    }
}
if($current_branch){
    say colored($current_branch, "green");
}else{
    say colored("Unable to find current branch", "red");
}
