From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 04 Jan 2008 16:28:18 +0000
Subject: Re: dccp send
Message-Id: <20080104172818.tlobczndj4w84480@oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald <ian.mcdonald@jandi.co.nz>:
> Correct. Remember of course all your locking mechanisms. If you want a
> good example look at the below towards the end:
> http://wand.net.nz/~iam4/dccp/patches20/30-best_packet_next.diff
>
> (NB this patch applies against 2.6.20 after previous patches in series).
>
Thanks. But while we are at your patch I have one more question: why  
did you choose to implement the algorithm it in ccid3? Shouldn't  
packet priorities and expiration times be processed indepentent of  
ccids? Until now it seemed for me that ccids only control _when_ you  
send data, _what_ you send should be determined by other means. Am I  
missing something here?
-- 
Regards,
Tomasz Grobelny
