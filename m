From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 10:08:41 +0000
Subject: Re: [PATCH 3/3]: Convert Reset code into socket error number
Message-Id: <200710021108.41257@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709291744.53552@strip-the-willow>
In-Reply-To: <200709291744.53552@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Yes you are correct. I misread the code.
|  
|  However - I'd prefer another constant to match last in enum at the
|  same point as the declaration of the enum. This way if values are
|  added other code doesn't break. I've seen this done before quite a few
|  times. It is dangerous on relying on the last value when it's not
|  explicitly marked as the last value.
Sorry I was replying to emails in-order and this one was later in the pile, so
please disregard most of the previous email.
Your suggestion is a useful improvement, which means that I will rework and the
resubmit.
