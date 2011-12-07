
CREATE TABLE [dbo].[category]
(
	[categoryId] [int] IDENTITY(1,1) NOT NULL,
	[parentCategoryId] [int] NULL,
	[categoryName] [varchar](50) NULL,
	CONSTRAINT [PK_category] PRIMARY KEY CLUSTERED
	(
		[categoryId] ASC
	)
)
GO

CREATE TABLE [dbo].[categoryNST]
(
	[treeId] [int] NOT NULL,
	[id] [int] NOT NULL,
	[lft] [int] NOT NULL,
	[rgt] [int] NOT NULL,
	CONSTRAINT [PK_categoryNST] PRIMARY KEY CLUSTERED 
	(
		[treeId] ASC,
		[id] ASC
	)
)
GO

CREATE NONCLUSTERED INDEX [IDX_categoryNST1] ON [dbo].[categoryNST] 
(
	[treeId] ASC,
	[id] ASC,
	[lft] ASC
)
GO

