# Specify the path to the Excel file and the WorkSheet Name
$FilePath = "$PSScriptRoot\Tickets.xls"
$SheetName = "Sheet1"

# Connect to Active Directory
import-module ActiveDirectory

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
$WorkBook = $objExcel.Workbooks.Open($FilePath)

# Load the WorkSheet 'Sheet1'
$WorkSheet = $WorkBook.sheets.item($SheetName)

# Count max row
$rowMax = ($Worksheet.UsedRange.Rows).count

# Loop to get email addresses
for ($i=2; $i -le $rowMax; $i++)
{
    $Status = $WorkSheet.Cells.Item($i,5).text
    
    if ($Status -eq 'Resolved') {
        $IncidentID = $WorkSheet.Cells.Item($i,1).text + ":"
        $Username = $WorkSheet.Cells.Item($i,2).text
        $Subject = $WorkSheet.Cells.Item($i,4).text
    
        $FirstName = (Get-ADuser -Identity $Username -Properties GivenName).GivenName
        $Email = (Get-ADuser -Identity $Username -Properties Mail).Mail
    
        $Body = "<BODY style='font-family:Consolas;font-size:10.5pt'>"
        $Body += "Dear $FirstName,<br><br>"
        $Body += "We are informed that your reported issue has been resolved/request has been fulfilled.<br><br>"
        $Body += "May we close your call?<br><br>"
        $Body += "Best regards,<br>"
        $Body += "Service Desk<br>"
        $Body += "</BODY>"
        Send-Mailmessage -to $Email -bcc servicedesk@adatum.com -from servicedesk@adatum.com -subject "Incident ID $IncidentID $Subject" -BodyasHtml -Body $Body -SmtpServer smtp.adatum.com
    }
}

# Closing Workbook and Excel
$Workbook.Close()                                                            
$objExcel.Quit()