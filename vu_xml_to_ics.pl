#!/usr/bin/perl

#Author: Yuri Henrique Borges

#INSTRUCTIONS:
# 1- Open https://webapi.login.vu.nl/api/student/getstudentid/{vunetId}/EN
# 2- Copy your student id
# 3- Open https://webapi.login.vu.nl/pi/study/events/{studentId}/{language}/{startdate}/{enddate}
# Where {language}= EN or NL, {startdate} and {enddate} in the form: 01-09-2017
# 4- Save the XML as rooster.ics in the same folder as this script
# 5- Execute ./vu_xml_to_ics.pl rooster.xml 
# 6- Open the generated rooster.ics with your preferred calendar and enjoy!

#Note not working properly


$xmlfile = @ARGV[0];
if ( ! $xmlfile ) {
	print "Provide the XML with your VU rooster at attribute\n" ; 
	exit 0;
}

$ics = $xml;
$ics =~ s/\.xml$/.ics/g;

open (ICSFILE,">$icsfile");
print "Writing to $icsfile\n";
print ICSFILE "BEGIN:VCALENDAR\n\n";
open (XMLFILE,$xmlfile);

$noteEntered = 0;

$codeAmount = 0;

while (<XMLFILE>) {
        $line = $_;
        if (/<Event/) {
        	print ICSFILE "BEGIN:VEVENT\n";
        }
        if (/<BlackBoardCourseId/){
                @fields = split(/<BlackBoardCourseId>|<\/BlackBoardCourseId>/,$line,3);
                $BlackBoardCourseId = @fields[1];
                print ("BlackBoardCourseId: $BlackBoardCourseId\n");
        }
        if (/<CourseCode/){
                @fields = split(/<CourseCode>|<\/CourseCode>/,$line,3);
                $CourseCode = @fields[1];
                print ("CourseCode: $CourseCode\n");
        }
        if (/<End/){
                @fields = split(/<End>|<\/End>/,$line,3);
                $End = @fields[1];
                $End =~ s/-|://g;
                print ("End: $End\n");
        }
        if (/<IsExam/){
                @fields = split(/<IsExam>|<\/IsExam>/,$line,3);
                $IsExam = @fields[1];
                print ("IsExam: $IsExam\n");
        }        
        if (/<Code/){
                @fields = split(/<Code>|<\/Code>/,$line,3);
                if ($codeNumber){
                	if($Code ne "@fields[1] ") {
                		$Code .= "@fields[1] ";
                	}
                } else {
                	$Code = "@fields[1] ";
                	$codeNumber = 1;
                }
                print ("Code: $Code\n");
        }
        if (/<\/Locations/){
               $codeNumber = 0;
        }
        if (/<Mandatory/){
                @fields = split(/<Mandatory>|<\/Mandatory>/,$line,3);
                $Mandatory = @fields[1];
                print ("Mandatory: $Mandatory\n");
        }
        if ($noteEntered == 1) {
        		$Note = $line;
        		print ("Notes: $Note\n");
        		$noteEntered = 0;
        }
        if (/<Note>\n/){
        		$noteEntered = 1;
        }
        if (/<Note>|<\/Note>/){
                @fields = split(/<Note>|<\/Note>/,$line,3);
                if (@fields[1] != 0){
                	$Note = @fields[1];
                	print ("Note: $Note\n");
                }
        }
		if (/<ShowBlackboardLink/){
                @fields = split(/<ShowBlackboardLink>|<\/ShowBlackboardLink>/,$line,3);
                $ShowBlackboardLink = @fields[1];
                print ("ShowBlackboardLink: $ShowBlackboardLink\n");
        }
        if (/<Start/){
                @fields = split(/<Start>|<\/Start>/,$line,3);
                $Start = @fields[1];
                $Start =~ s/-|://g;
                print ("Start: $Start\n");
        }
        if (/<Summary/){
                @fields = split(/<Summary>|<\/Summary>/,$line,3);
                $Summary = @fields[1];
                print ("Summary: $Summary\n");
        }
        if (/<Title/){
                @fields = split(/<Title>|<\/Title>/,$line,3);
                $Title = @fields[1];
                print ("Title: $Title\n");
        }
        if (/<Type/){
                @fields = split(/<Type>|<\/Type>/,$line,3);
                $Type = @fields[1];
                print ("Type: $Type\n\n");
        }
        if (/<\/Event/){
				# DTEND;TZID=Europe/Amsterdam:20160601T170000
				print ICSFILE "DTEND;TZID=Europe/Amsterdam:$End\n";
				# LOCATION:Aula CZ B
				print ICSFILE "LOCATION:$Code\n";
				# DESCRIPTION:Student set(s): Technische Natuurkunde 1 groep 1\, Technisch
				print ICSFILE "DESCRIPTION:$Note\n";
				# SUMMARY:TN1661 - Oriëntatie op Natuurkundeonderzoek
				print ICSFILE "SUMMARY:$Title $CourseCode $Type\n";
				# DTSTART;TZID=Europe/Amsterdam:20160601T144500
				print ICSFILE "DTSTART;TZID=Europe/Amsterdam:$Start\n";
        		print ICSFILE "END:VEVENT\n\n";
        		$BlackBoardCourseId = 0;
        		$CourseCode = 0;
        		$End = 0;
        		$IsExam = 0;
        		$Mandatory = 0;
        		$Note = 0;
        		$ShowBlackboardLink = 0;
        		$Start = 0;
        		$Summary = 0;
        		$Title = 0;
        		$Type = 0;
        }
}
close (XMLFILE);
print ICSFILE "END:VCALENDAR\n";
close (ICSFILE);
