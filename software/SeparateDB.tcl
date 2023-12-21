console show
package require sqlite3
proc SepDB {targ} {
  set dbLocation //prod-svm1/tds/temp/SQLiteDB
  if ![file exists $dbLocation] {
    set res [tk_messageBox -type ok -title "DB Location" -icon error -message "No access to $dbLocation"]
    if {$res=="no"} {
      exit
    } else {
      return {}
    }
  }
  
  set sourDBfile [file join $dbLocation JerAteStats.db]
  set locSourDBfile JerAteStats.db
  set targDBfile [file join $dbLocation $targ.db]
  set locTargDBfile $targ.db
  
  set tim [time {file copy -force $sourDBfile $locSourDBfile}]
  puts "tim1:<$tim>"
  set tim [time {file delete -force $locTargDBfile}]
  puts "tim2:<$tim>"
  
  
  set sec1 [clock seconds]
  sqlite3 targDB $locTargDBfile
  targDB timeout 8000
  
  targDB eval {CREATE TABLE tbl(Barcode, UutName, HostDescription, Date, Time, Status, FailTestsList, FailDescription, DealtByServer)}
  
  catch {targDB eval {attach $locSourDBfile as "alias"}} res
  #puts "res2:<$res>" ; update
  catch {targDB eval {insert into tbl select * from alias.tbl \
    where HostDescription LIKE "%phili%"}} res 
    ##  AND HostDescription NOT LIKE "%tag%" Date >= 2023.12.18 AND HostDescription LIKE "%hili%"
  #puts "res3:<$res>" ; update 
  catch {targDB eval {detach "alias"}} res
  #puts "res4:<$res>" ; update
    
  catch {targDB  close} resT
  #puts "close sour <$resS>\nclose targ:<$resT>"   
  
  set sec2 [clock seconds] 
  puts "[expr {$sec2 -$sec1}] secs"
  
  set tim [time {file copy -force $locTargDBfile $targDBfile}]
  puts "tim3:<$tim>"
  
  set tim [time {file delete -force $locSourDBfile}]
  puts "tim4:<$tim>"
  set tim [time {file delete -force $locTargDBfile}]
  puts "tim5:<$tim>"
}

SepDB Philippines