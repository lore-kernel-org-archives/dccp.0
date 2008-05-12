From: Tommi Saviranta <wnd@iki.fi>
Date: Mon, 12 May 2008 10:39:37 +0000
Subject: Re: CCID4 Testing - bug fix
Message-Id: <20080512103937.GA6034@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
In-Reply-To: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 12, 2008 at 11:26:37 +0100, Gerrit Renker wrote:
> | Patch details: we modify the sender rate in the initial phase when
> | congestion control is not yet applied. In the original code, the header
> | penalty rate reduction of s/(s+overhead) was, I believe, incorrectly
> | applied to all sender rates. 
> 
> The CCID4-02 draft indeed speaks of "allowed transmit rate derived from
> the TCP throughput equation" in section 5, which seems to imply that X_calc
> (and not X in general) is meant, which confirms your interpretation.

I've been wondering why CCID 4 performed like this, but somehow I came
to accept this as a feature. Now it appears that I've been blind to my
own mistakes. Good thing someone spotted this.

