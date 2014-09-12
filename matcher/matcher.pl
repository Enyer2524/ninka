#!/usr/bin/env perl
#
#    Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# matchter.pl
#
# This script uses a set of license sentence names as input and
# outputs license names corresponds to a rule which match the set.
#

use strict;
#use warnings;
use File::Basename qw(dirname);
use Getopt::Std;

my %NON_CRITICAL_RULES = ();

# these should go into a file, but for the time being, let us keep them here
# once we have matched a rule, these are not that important

my @GENERAL_NON_CRITICAL = ('AllRights');

my @GPL_NON_CRITICAL = ('GPLnoVersion',
                        'FSFwarranty',
                        'LibraryGPLcopyVer0',
                        'GPLseeVer0',
                        'GPLwrite',
                        'SeeFile',
                        'FreeSoftware',
                        'FSFwarrantyVer0',
                        'LibraryGPLseeDetailsVer0',
                        'FSFwarranty',
                        'LesserGPLseeDetailsVer0',
                        'GPLcopyVer0',
                        'GNUurl',
                        'GPLseeDetailsVer0');

$NON_CRITICAL_RULES{'LibraryGPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv3'} = [@GPL_NON_CRITICAL, 'LesserGPLseeVer3', 'LesserGPLcopyVer3', 'SeeFileVer3'];
$NON_CRITICAL_RULES{'LesserGPLv2.1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2.1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLv2orv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2+'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'GPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'AGPLv3'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'AGPLv3+'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'GPLnoVersion'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'Apachev1.1'} = ['ApacheLic1_1'];
$NON_CRITICAL_RULES{'Apachev2'} = ['ApachePre', 'ApacheSee'];

$NON_CRITICAL_RULES{'LibGCJLic'} = ['LibGCJSee'];
$NON_CRITICAL_RULES{'CDDLicV1'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];
$NON_CRITICAL_RULES{'CDDLic'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];

$NON_CRITICAL_RULES{'CDDLorGPLv2'} = ['CDDLorGPLv2doNotAlter', 'AllRights', 'useOnlyInCompliance', 'CDDLorGPLv2whereVer0', 'ApachesPermLim', 'CDDLorGPLv2include', 'CDDLorGPLv2IfApplicable', 'CDDLorGPLv2Portions', 'CDDLorGPLv2ifYouWishVer2', 'CDDLorGPLv2IfYouAddVer2'];

$NON_CRITICAL_RULES{'CPLv1orGPLv2+orLGPLv2+'} = ['licenseBlockBegin', 'licenseBlockEnd'];

$NON_CRITICAL_RULES{'Qt'} = ['Copyright', 'qtNokiaExtra', 'QTNokiaContact', 'qtDiaTems'];
$NON_CRITICAL_RULES{'orLGPLVer2.1'} = ['LesserqtReviewGPLVer2.1', 'qtLGPLv2.1where'];
$NON_CRITICAL_RULES{'orGPLv3'} = ['qtReviewGPLVer3.0', 'qtReviewGPLVer3', 'qtGPLwhere'];
$NON_CRITICAL_RULES{'digiaQTExceptionNoticeVer1.1'} = ['qtDigiaExtra'];

$NON_CRITICAL_RULES{'MPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'MPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];

$NON_CRITICAL_RULES{'subversion'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'subversion+'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'tmate+'} = ['SeeFileSVN'];

$NON_CRITICAL_RULES{'openSSLvar2'} = ['BSDcondAdvPart2'];

$NON_CRITICAL_RULES{'MPLv1_1'} = ['licenseBlockBegin', 'MPLsee', 'Copyright', 'licenseBlockEnd', 'ApacheLicWherePart1', 'MPLwarranty', 'MPLwarrantyVar'];
$NON_CRITICAL_RULES{'MPL1_1andLGPLv2_1'} = ['MPLoptionIfNotDelete2licsVer0', 'MPL_LGPLseeVer0'];

$NON_CRITICAL_RULES{'FreeType'} = ['FreeTypeNotice'];

$NON_CRITICAL_RULES{'GPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];

my $INPUT_FILE_EXTENSION = 'senttok';

my %opts = parse_cmdline_parameters();

my $verbose = exists $opts{v};

my $path = dirname($0);

my $input_file = $ARGV[0];
my $rules_file = "$path/rules.dict";
my $interrules_file = "$path/interrules.dict";

my @license_sentence_names = ();
my @originals = ();
read_original($input_file, \@license_sentence_names, \@originals);

my @rules = read_rules($rules_file);
my @inter_rules = read_inter_rules($interrules_file);

##########################################

# matching spdx requires to match strict licenses, with no alternatives...

my @result = ();
my $count_matches = 0;

my $senttok = ',' . join(',', @license_sentence_names) . ',';
print STDERR "senttok [$senttok]\n" if $verbose;
match_license();

# do we have to check again?
## todo, verify that we have unmatched sentences...

@license_sentence_names = split ',', $senttok;

# first remove the extrict part from it
my $match = 0;
for (my $i = 0; $i <= $#license_sentence_names; $i++) {
    if ($license_sentence_names[$i] == 0 &&
        $license_sentence_names[$i] ne 'UNKNOWN' &&
        $license_sentence_names[$i] ne '') {
        $license_sentence_names[$i] =~ s/Extrict$//;
        $match++;
    }
}

if ($match) {
    foreach my $inter_rule (@inter_rules) {
        @license_sentence_names = map { $_ eq $inter_rule->[0] ? $inter_rule->[1] : $_ } @license_sentence_names;
    }

    $senttok = join(',', @license_sentence_names) . ',';
    print STDERR "senttok [$senttok]\n" if $verbose;
    match_license();
}

print_result($senttok);

exit 0;

sub parse_cmdline_parameters {
    my %opts = ();
    if (!getopts('v', \%opts) || scalar(@ARGV) == 0 || $ARGV[0] !~ /\.$INPUT_FILE_EXTENSION$/) {
        print STDERR "Usage $0 [options] <filename>.$INPUT_FILE_EXTENSION

Options:
  -v verbose\n";

        exit 1;
    }
    return %opts;
}

sub is_unknown {
    my ($s) = @_;
    my @f = split /,/, $s;
    return $f[0] eq 'UNKNOWN';
}

sub read_rules {
    my ($file) = @_;
    my @rules = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        # clean up spaces
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        $line =~ s/\s*,\s*/,/g;
        $line =~ s/\s*:\s*/:/g;
        # check format
        if ($line =~ /^#/ || $line !~ /(.*):(.*,)*(.*)/) {
            next;
        }
        $line =~ /(.*?):(.*)/;
        push @rules, [$1, $2];
    }

    close $fh;

    return @rules;
}

sub read_inter_rules {
    my ($file) = @_;
    my @inter_rules = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        # check format
        if ($line =~ /^#/ || $line !~ /(.*?):(.*)/) {
            next;
        }
        foreach my $item (split /\|/, $2) {
            push @inter_rules, [$item, $1];
        }
    }

    close $fh;

    return @inter_rules;
}

sub read_original {
    my ($file, $tokens, $originals) = @_;

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $sentence = <$fh>) {
        chomp $sentence;
        my @fields = split ':', $sentence;
        push @$originals, $fields[1];
        my @token = split ';', $fields[0];
        push @$tokens, $token[0];
    }

    close $fh;

    if (scalar(@$originals) == 0) {
        print "NONE\n";
        exit 0;
    }
}

# we will iterate over rules, matching as many as we can...
sub match_license {
    # create a string with the sentences
    foreach my $rule (@rules) {
        my ($rule_name, $rule_tokens) = @$rule;
        my $rule_length = scalar(split ',', $rule_tokens);

        print STDERR "trying [$rule_name][$rule_tokens] on [$senttok]\n" if $verbose;
        while ($senttok =~ s/,$rule_tokens,/,$rule_length,/) {
            print STDERR "rule matched\n" if $verbose;
            $count_matches++;
            push @result, $rule_name;
        }
    }

    # at this point we have removed all the matched sentences...
    print STDERR "senttok after matching rules [$senttok]\n" if $verbose;
    print STDERR "result after matching rules [" . join(',', @result) . "]\n" if $verbose;

#    # let us remove allrights
#    my $only_all_right = 1;
#    for my $i (0.. scalar(@license_sentence_names)-1){
#        if ($license_sentence_names[$i] eq 'AllRights') {
#            $license_sentence_names[$i] = '';
#        } else {
#            $only_all_right = 0;
#        }
#    }

    # output result
    if (scalar(@result) > 0) {
        # at this point we have matched

        # let us clean up the rules... let us print the matched rules, and the
#    if (grep(/GPL/, @result)) {
#        print "GPL...\n";
#        foreach my $r ($NON_CRITICAL_RULES{GPL}) {
#            $senttok =~ s/(,|^)$r(,|$)/$1$2/g;
#        }
#    }

        foreach my $rule (@GENERAL_NON_CRITICAL) {
            while ($senttok =~ s/,$rule,/,-1,/) {
                ;
            }
        }
        print STDERR "senttok after removal of general non-critical rules [$senttok]\n" if $verbose;

        foreach my $rule_name (@result) {
            foreach my $rule (@{$NON_CRITICAL_RULES{$rule_name}}) {
                while ($senttok =~ s/,$rule,/,-1,/g) {
                    ;
                }
            }
        }
        print STDERR "senttok after removal of non-critical rules [$senttok]\n" if $verbose;
    }
}

sub print_result {
    my ($senttok) = @_;

#   $senttok =~ s/AllRights(,?)/$1/g;
#   $senttok =~ s/UNKNOWN,/,/g;
#   $senttok =~ s/,+/,/g;

    my @sections = split ',', $senttok;
    die 'assertion 1' if $sections[0] ne '';
    die 'assertion 2' if $sections[scalar(@sections)] ne '';

    my $ignored_lines = 0;
    my $license_lines = 0;
    my $unknown_lines = 0;
    my $unmatched_lines = 0;

    foreach my $i (1..scalar(@sections)-1) {
        if ($sections[$i] < 0) {
            $ignored_lines -= $sections[$i];
        } elsif ($sections[$i] != 0) {
            $license_lines += $sections[$i];
        } elsif ($sections[$i] eq 'UNKNOWN') {
            $unknown_lines++;
        } else {
            $unmatched_lines++;
        }
    }
    $senttok =~ s/^,(.*),$/$1/;

    if (scalar(@result) == 0) {
        print 'UNKNOWN';
    } else {
        print join ',', @result;
    }
    # ok, so now, what I want to output is:
    # licenses; number of licenses matched;number of sentences matched; number of sentences ignored;number of sentences not matched;number of sentences unknown
    print ";$count_matches;$license_lines;$ignored_lines;$unmatched_lines;$unknown_lines;$senttok\n";
}

