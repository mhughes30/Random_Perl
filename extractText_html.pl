#! /usr/bin/perl

use strict;
use warnings;
use CGI;
use DateTime;
use Path::Class;
use Cwd;
use Class::Struct;

my $fileIn = "someText.txt";
# dot indicates teh current directory
# q is shorthand for putting quotes around the enclosed item
my $dirIn = getcwd();

my $fileOut = q(output.html);

print("Starting....");

##### --- Read in the Data
my $dir    = dir($dirIn);	        #directory
my $file   = $dir->file($fileIn); #file
my $dataIn = $file->slurp();        #"slurp" up data from file

print("\n");

##### --- Open the output file
my $FILE_OUT = $dir->file($fileOut);
my $fileOutHandle = $FILE_OUT->openw();

##### --- This is a CGI/HTML class 
my $q = new CGI;

# position indicators
my $curStart   = 0;	
my $curEnd     = 0;
my $curLen 	   = 0;
my $subContent = "";

# a hash of results
my %results;

### ---- Search terms
my $newLine = "\n";
my $space   = " ";

### ---- Result arrays
my @itemArray;
my @col2Array;
my @col3Array;

# First, remove the data at the top
my $numNewLinesAtTop = 8;
my $idx = 0;
while ($idx < $numNewLinesAtTop)
{
	$curStart = index($dataIn, $newLine) + 1;	
	$dataIn   = substr( $dataIn, $curStart);
	$idx      = $idx + 1;
}

my $startIdx = 0;
while (1)
{
	# Find each line
	$curStart   = index($dataIn, $newLine);
	# -1 is returned by index() when a newLine is no longer found
	if ($curStart == -1)
	{
		last;
	}
	$curStart = $curStart + 1;
	$curLen		= $curStart - 1;
	# subContent is one lines worth of data
	$subContent = substr($dataIn, 0, $curLen);
			
	# Now, extract each field from subContent based upon 
	# whitespace, using regular expressions
	my @curVal = split(/\s/, $subContent);
	push(@itemArray, $curVal[0]);
	push(@col2Array, $curVal[1]);
	push(@col3Array, $curVal[2]);
		
	$dataIn = substr($dataIn, $curStart);
}

#### --------- Create HTML Output
$fileOutHandle->print($q->header . "\n");
my $start = $q->start_html( -title => "QCOM - Why Wait" );
$fileOutHandle->print($start . "\n");

##### ----- Building the table
my $tableStart = $q->start_table({-border=>1, -cellspacing=>2, -cellpadding=>1});
$fileOutHandle->print($tableStart . "\n");

# table header
my @headerArray = ('Item', 'Column 2', 'Column 3');
my $table1 = $q->Tr({-align=>'center',-valign=>'middle'},[$q->th(\@headerArray)]);
$fileOutHandle->print($table1 . "\n");

# rows of the table
$idx = 0;
foreach my $curItem (@itemArray)
{
	my @row = ($itemArray[$idx], $col2Array[$idx], $col3Array[$idx]);

	my $curStr = $q->Tr({-align=>'center',-valign=>'middle'},[$q->td(\@row)]);

	$fileOutHandle->print($curStr . "\n");
	
	$idx = $idx + 1;
}

my $end = $q->end_table();
$fileOutHandle->print($end . "\n");

$fileOutHandle->print($q->end_html . "\n");
 

exit 0;
 
 




