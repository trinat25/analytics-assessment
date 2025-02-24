/*
SQL Programming

Skills used: Joins, CTE's, aggregate functions, CAST or converting of data types, window functions

*/


-- 1. The names and the number of messages sent by each user 

SELECT 
  a.Name,
  count(b.MessageID) Messages 
FROM User a 
JOIN Messages b on a.UserID = b.UserIDSender
GROUP BY 1
ORDER BY 2 DESC; 


-- 2. The total number of messages sent stratified by weekday

SELECT 
  DAYNAME(DATE(DateSent)) as Weekday,
  COUNT(MessageID) as TotalMessages, 
  ROUND(COUNT(MessageID) * 100.0 / (SELECT COUNT(MessageID) FROM Messages), 2) AS PercentageOfTotal
FROM Messages 
GROUP BY 1 
ORDER BY FIELD(Weekday,'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'); 

/*
In this solution, I also recommend adding a column showing the percentage of the total.
This would help stakeholders quickly identify the most popular day and easily compare values, such as Sunday at 10% versus Tuesday at 20%.
Here is an example output:
| Weekday   | TotalMessages | PercentageOfTotal|
|-----------|---------------|------------------|
| Sunday    | 150           | 10.25%           |
| Monday    | 250           | 17.10%           |
| Tuesday   | 300           | 20.50%           |
| Wednesday | 220           | 15.07%           |
| Thursday  | 180           | 12.32%           |
| Friday    | 280           | 19.18%           |
| Saturday  | 120           | 8.58%            | 

Why Should You Cast DateSent to DATE?
Without Casting: The DAYNAME() function works directly on DATETIME, but it still processes the time component internally.
With Casting: Using CAST(DateSent AS DATE) or DATE(DateSent) makes the query more efficient and clear, especially for large datasets.
*/


-- 3. The most recent message from each thread that has no response yet

/*
Reasoning Behind the Code
Assumption:  
Every message thread begins with a sender. Based on this, I've introduced a thread status labeled "No response – Single message" for cases where no reply is received.

Unanswered Threads: 
  1. Waiting on Recipient: The sender sent the last message.
  2. Waiting on Sender: The recipient sent the last message.

Further Analysis:  
  In a real-world scenario, I would analyze the final message content to determine if a reply is expected. For example, phrases like "Thank you", "Got it", or "No worries" might indicate that no further response is needed. Natural language processing (NLP) techniques could automate this identification.

Tracking Trends:  
  I could also calculate response rates over time, such as:
  - (Latest thread by sender / Total messages sent by sender)
  - (Latest thread by recipient / Total messages sent by recipient)
  
  Tracking these metrics as a time series would help identify seasonal trends, shifts in communication behavior, and long-term changes in response rates.
*/

WITH ThreadLastMessage AS (
    SELECT 
        ThreadID,
        MessageID,
        MessageContent,
        UserIDSender AS LastSender,
        UserIDRecipient AS LastRecipient,
        DateSent,
        ROW_NUMBER() OVER (PARTITION BY ThreadID ORDER BY DateSent DESC) AS rn_desc
    FROM Messages
)
SELECT 
    tl.ThreadID,
    tl.MessageID,
    tl.MessageContent,
    tl.DateSent,
    CASE 
        WHEN m_sender.MessageID IS NULL AND m_recipient.MessageID IS NULL THEN 'No response yet (Single message)'
        WHEN m_sender.MessageID IS NULL THEN 'Waiting for Recipient response'
        WHEN m_recipient.MessageID IS NULL THEN 'Waiting for Sender response'
    END AS ThreadStatus
FROM ThreadLastMessage tl
LEFT JOIN Messages m_sender 
    ON tl.ThreadID = m_sender.ThreadID
    AND m_sender.UserIDSender = tl.LastRecipient
    AND m_sender.DateSent > tl.DateSent
LEFT JOIN Messages m_recipient 
    ON tl.ThreadID = m_recipient.ThreadID
    AND m_recipient.UserIDSender = tl.LastSender
    AND m_recipient.DateSent > tl.DateSent
WHERE tl.rn_desc = 1 
  AND (m_sender.MessageID IS NULL OR m_recipient.MessageID IS NULL)
ORDER BY tl.DateSent DESC;


-- 4. For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation

WITH ThreadMessageCounts AS (
    SELECT ThreadID, COUNT(MessageID) AS MessageCount
    FROM Messages
    GROUP BY ThreadID
    ORDER BY MessageCount DESC
    LIMIT 1
),
RankedMessages AS (
    SELECT 
        a.ThreadID,
        a.MessageID,
        u_sender.Name AS Sender,
        u_recipient.Name AS Recipient,
        a.MessageContent,
        a.DateSent,
        LAG(a.DateSent) OVER (PARTITION BY a.ThreadID ORDER BY a.DateSent ASC) AS PreviousDateSent
    FROM Messages a
    JOIN User u_sender ON a.UserIDSender = u_sender.UserID
    JOIN User u_recipient ON a.UserIDRecipient = u_recipient.UserID
    WHERE a.ThreadID = (SELECT ThreadID FROM ThreadMessageCounts)
)
SELECT 
    ThreadID,
    MessageID,
    Sender,
    Recipient,
    MessageContent,
    DateSent,
    TIMESTAMPDIFF(SECOND, PreviousDateSent, DateSent) AS ResponseTimeInSeconds
FROM RankedMessages
ORDER BY DATE(DateSent) ASC;


/*
In this solution, I propose to also show response time. Some benefits to include this are 
- Conversation Flow: Reveals how quickly users respond, which can indicate engagement and urgency.
- User Engagement: Longer response times might indicate lower engagement or delayed conversations.
- Performance Tracking: Can help monitor whether users are responding within an expected timeframe. 

Potential output can look like the below: 
| ThreadID  |  MessageID    |      Sender| Recipient     | MessageContent                            | DateSent                 | ResponseTimeInSeconds    |
|-----------|---------------|------------|---------------|-------------------------------------------|--------------------------|--------------------------|
| 1         | 101           | Alice      | Bob           | Hi, how are you?                           | 2024-02-10 09:00:00     | NULL                     |
| 1         | 102           | Bob        | Alice         | I'm good, thanks! How about you?           | 2024-02-10 09:05:00     | 300                      |
| 1         | 103           | Alice      | Bob           | Doing well, thanks for asking!             | 2024-02-10 09:07:00     | 120                      |
| 1         | 104           | Bob        | Alice         | Great to hear! Are you free later?         | 2024-02-10 09:15:00     | 480                      |
| 1         | 105           | Alice      | Bob           | Yes, I should be free after lunch.         | 2024-02-10 09:20:00     | 300                      |
*/
