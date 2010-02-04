From: David Miller <davem@davemloft.net>
Date: Thu, 04 Feb 2010 03:01:42 +0000
Subject: Re: [PATCH v2 1/1] dccp: fix auto-loading of dccp(_probe)
Message-Id: <20100203.190142.123408896.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 3 Feb 2010 06:58:40 -0500

> On Wed, Feb 03, 2010 at 07:16:56AM +0100, Gerrit Renker wrote:
>> Hi Neil,
>> 
>> I have tested your patch, it works fine thanks to the repeated execution of the macro
>> argument. I have reformatted it, removing the inner parentheses, which I think is
>> justified since macros copy their arguments in full. Also converted your email to a
>> drafted commit message. Due to this, have not copied your signed-off -- if you are
>> ok, please add, this should be submitted asap.
>> 
> Understood, and thank you.  This looks fine to me
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
