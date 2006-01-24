From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 24 Jan 2006 11:10:16 +0000
Subject: service code bug in linux & tcpdump
Message-Id: <20060124111016.GA1159@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

shouldn't the service code [u32] be in network byte order?

If so, linux:
net/dccp/output.c:105
should have a htonl();

tcpdump:
print-dccp.c:~304
should have EXTRACT_32BITS();


if it really is an error, other places in the code probably have it.
