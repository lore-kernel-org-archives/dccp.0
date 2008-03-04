From: babil <golam.sarwar@nicta.com.au>
Date: Tue, 04 Mar 2008 11:41:17 +0000
Subject: dccp_pr_debug or probe.c ?
Message-Id: <200803042241.17855.golam.sarwar@nicta.com.au>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi list,

Could anyone please tell me how to grab "dccp_pr_debug" outputs ?? I'm using 
kernel 2.6.20.

I needed to print the loss-interval array (li_entry->dccplih_interval) for 
which I modified the probe.c. But, it wont print anything 
inside "list_for_each_entry_safe(li_entry, li_next, list, dccplih_node)".

I'm attaching my modified probe.c. My modifications are marked with "babil". 
If it cant work, if anyone could please tell me how to grab "dccp_pr_debug" 
outputs, that would have been a great help.

I've also tried putting printk's in loss_interval.c, but failed catch any 
output.

Kind Regards,
-Golam Sarwar (babil)
