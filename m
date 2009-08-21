From: Julien.HUEBER@fr.thalesgroup.com
Date: Fri, 21 Aug 2009 08:22:45 +0000
Subject: DCCP module insertion issues
Message-Id: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello, 
I am currently working on DCCP in a research purpose but I am experiencing
new issues that I don't understand.
 
We already have a Test-Bed with a couple of machines working with the latest
version of the Linux Kernel (2.6.31-rc1) modified for DCCP, but when we
tried to install this kernel on another computer the DCCP module isn't
loading.
 
When we try to insert it manually we get the following error :
# sudo insmod dccp.ko
> insmod: error inserting 'dccp.ko' : -1 Socket type not supported
 
We saw on the mailing list that this error can be caused by the timer
resolution (on the post "dccp ccid3 : Runtime verification of timer
resolution"). Our clocksource was "tsc", but even when changing it to
"acpi_pm" (which is working just fine with DCCP on another machine) we are
still getting this error.
Moreover, DCCP used to work on this machine when an older version
(2.6.26-rc8) of the modified Kernel was installed.
 
So I am running out of idea about this problem, if anyone could explain me
what is the matter, or how can I get rid of it, it would be very helpful.
Thanks,
--
Julien Hueber
 
MSc student in internship at Thales Communications
