From: Julien.HUEBER@fr.thalesgroup.com
Date: Wed, 26 Aug 2009 16:27:03 +0000
Subject: RE: DCCP module insertion issues
Message-Id: <DD7F6BACE0940D4AA451F8762B4D513C02605627@thot.clb.tcfr.thales>
List-Id: <dccp.vger.kernel.org>
References: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
In-Reply-To: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

You were right, the timer_list indicates that I have a .resolution of 999484 nsecs, which can explain why I had a value of 999 usec in the error message of the log.

I set my .config file fields as yours and recompiled but the value of .resolution is still the same. Despite that I can at least identify where the problem is now. 

Thank you.
