From: Bob Peterson <rpeterso@redhat.com>
Date: Tue, 02 Jan 2018 13:52:38 +0000
Subject: Re: [Cluster-devel] [PATCH 00/12] drop unneeded newline
Message-Id: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

----- Original Message -----
| Drop newline at the end of a message string when the printing function adds
| a newline.

Hi Julia,

NACK.

As much as it's a pain when searching the source code for output strings,
this patch set goes against the accepted Linux coding style document. See:

https://www.kernel.org/doc/html/v4.10/process/coding-style.html#breaking-long-lines-and-strings

Regards,

Bob Peterson
