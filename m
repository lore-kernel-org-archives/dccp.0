From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 02 Jan 2008 00:41:16 +0000
Subject: dccp send
Message-Id: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When I use dccp does sendmsg function block (until it sends the packet)? If 
so, should it? In either case, how to make it just queue the packet and 
return?
-- 
Regards,
Tomasz Grobelny
