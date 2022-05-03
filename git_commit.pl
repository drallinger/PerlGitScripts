#!/usr/bin/perl
use strict;
use warnings;
use feature "say";
use Git::Repository;
use Term::UI;
use Term::ReadLine;
use Term::ANSIColor;
my $git = Git::Repository->new;
my $message = shift;
die "No commit message given\n" unless $message;
my @status = $git->run("status", "-s");
my @updates;
sub check_status {
    my $code = shift;
    my $path = shift;
    my $extra_path = shift;
    if($code eq "M "){
        push @updates, colored("Modified", "yellow") . " : $path"
    }elsif($code eq "A "){
        push @updates, colored("Added", "green") . "    : $path";
    }elsif($code eq "D "){
        push @updates, colored("Deleted", "red") . "  : $path";
    }elsif($code eq "R "){
        push @updates, colored("Renamed", "magenta") . "  :\n    Old name: $path\n    New name: $extra_path";
    }elsif($code eq "C "){
        push @updates, colored("Copied", "cyan") . "   :\n    Old file: $path\n    New file: $extra_path";
    }
}
for my $line(@status){
    if($line =~ m#^(.{2})\s(.+)\s->\s(.+)$#){
        check_status($1,$2,$3);
    }elsif($line =~ m#^(.{2})\s(.+)$#){
        check_status($1,$2);
    }
}
die "Nothing to commit\n" unless @updates;
my @branches = $git->run("branch");
my $current_branch;
for my $branch(@branches){
    if($branch =~ m#^\*\s(.+)$#){
        $current_branch = $1;
        last;
    }
}
die "Unable to find current branch\n" unless $current_branch;
my $ticket;
if($current_branch =~ m#^(?:(?:feature|hotfix|bugfix)/)?([A-Z][A-Z0-9]+-[0-9]+)#){
    $ticket = $1;
}
say "Branch: ", colored($current_branch, "green");
say "Changes:";
say " " x 2, $_ for @updates;
print "\n";
my $commit_message;
if($ticket){
    $commit_message = "$ticket: $message";
}else{
    $commit_message = $message;
}
say qq(Message: "$commit_message");
my $term = Term::ReadLine->new("Commit");
my $commit = $term->ask_yn(prompt => "Commit?");
if($commit){
    my $output = $git->run("commit", "-m", $commit_message);
    say $output;
}else{
    say "Canceling commit";
}
