
CREATE TABLE [dbo].[testNST]
(
	[treeId] [int] NOT NULL,
	[id] [int] NOT NULL,
	[lft] [int] NOT NULL,
	[rgt] [int] NOT NULL,
	CONSTRAINT [PK_testNST] PRIMARY KEY CLUSTERED 
	(
		[treeId] ASC,
		[id] ASC
	)
)
GO

