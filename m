From: Colin Perkins <csp@csperkins.org>
Date: Tue, 24 Apr 2007 22:50:11 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <851E97A0-036B-4AE0-A109-260991ECCF6B@csperkins.org>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 20 Apr 2007, at 12:31, Gerrit Renker wrote:
> |  Likewise - we have experiments in progress, and while we do have
> |  stability problems with our TFRC implementation, I'm unconvinced  
> the
> |  behaviour is due to the reasons suggested. I'll report back when we
> |  have more results.
> |
> I am not sure you mean the same problem.

Maybe - it's certainly possible there are several issues here.

> If you have data which relates to the problem described - and the  
> description is the result of experiments over several months -  
> please do post the results.

We have initial data, collected as part of an MSc project over the  
course of a year, which gives some indications as to the cause of the  
issues we're seeing. As I said, I'll report back when we have more  
data to confirm (or otherwise) those findings.

Colin
