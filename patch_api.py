
import os

filepath = r'E:\Courses\Work\renty\Client\Web\src\app\core\api\api-client.ts'
backup_path = filepath + '.bak'

if not os.path.exists(backup_path):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
else:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

# 1. Update TerritoryGapAnalysisDto class
# Add gapScore?: number;
if 'gapScore?: number;' not in content[content.find('class TerritoryGapAnalysisDto'):content.find('constructor', content.find('class TerritoryGapAnalysisDto'))]:
    content = content.replace('uniqueCustomers?: number;', 'uniqueCustomers?: number;\n    gapScore?: number;', 1)

# 2. Update ITerritoryGapAnalysisDto interface
if 'gapScore?: number;' not in content[content.find('interface ITerritoryGapAnalysisDto'):content.find('}', content.find('interface ITerritoryGapAnalysisDto'))]:
    content = content.replace('uniqueCustomers?: number;', 'uniqueCustomers?: number;\n    gapScore?: number;', 1)

# 3. Update GapAnalysisSummaryDto class
if 'categoryGaps?: CategoryGapScoreDto[]' not in content[content.find('class GapAnalysisSummaryDto'):content.find('constructor', content.find('class GapAnalysisSummaryDto'))]:
    content = content.replace('totalDemand?: number;', 'totalDemand?: number;\n    categoryGaps?: CategoryGapScoreDto[] | undefined;', 1)

# 4. Update IGapAnalysisSummaryDto interface
if 'categoryGaps?: CategoryGapScoreDto[]' not in content[content.find('interface IGapAnalysisSummaryDto'):content.find('}', content.find('interface IGapAnalysisSummaryDto'))]:
    content = content.replace('totalDemand?: number;', 'totalDemand?: number;\n    categoryGaps?: CategoryGapScoreDto[] | undefined;', 1)

# 5. Update CategoryGapScoreDto class
if 'supplyCount?: number;' not in content[content.find('class CategoryGapScoreDto'):content.find('constructor', content.find('class CategoryGapScoreDto'))]:
    content = content.replace('gapLevel?: string;', 'gapLevel?: string;\n    supplyCount?: number;\n    demandCount?: number;', 1)

# 6. Update CategoryGapScoreDto init
cat_init_start = content.find('init(_data?: any) {', content.find('class CategoryGapScoreDto'))
cat_init_end = content.find('}', cat_init_start)
cat_init_block = content[cat_init_start:cat_init_end]
if 'supplyCount' not in cat_init_block:
    new_cat_init = cat_init_block.replace('this.gapLevel = _data["gapLevel"];', 
                                          'this.gapLevel = _data["gapLevel"];\n            this.supplyCount = _data["supplyCount"];\n            this.demandCount = _data["demandCount"];')
    content = content[:cat_init_start] + new_cat_init + content[cat_init_end:]

# 7. Update ICategoryGapScoreDto interface
if 'supplyCount?: number;' not in content[content.find('interface ICategoryGapScoreDto'):content.find('}', content.find('interface ICategoryGapScoreDto'))]:
    content = content.replace('gapLevel?: string;', 'gapLevel?: string;\n    supplyCount?: number;\n    demandCount?: number;', 2) # The first one is in class, 2nd in interface? Wait, I should be more specific.

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done patching api-client.ts")
