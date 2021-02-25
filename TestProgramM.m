% Suppress all warnings
warning('off','all');

greenBuoyCount = 0; gateCount = 0; binCount = 0; torpedoCount = 0; yellowBuoyCount = 0; redBuoyCount = 0

dataStoreDir = "Data";
dataStoreInfo = dir(fullfile(dataStoreDir));

for i = 3:size(dataStoreInfo, 1)
    
    dataFolderName = dataStoreInfo(i, 1).name;
    strcmp(dataFolderName, strcat(dataStoreInfo(i-1, 1).name, "_ImageData"));
    
    if (strcmp(dataFolderName, strcat(dataStoreInfo(i-1, 1).name, "_ImageData")))
        "Image Data Folder Already Exists"
    else
        
        newDataDir = fullfile(dataStoreDir, strcat(dataFolderName, "_ImageData"));
        
        if ~exist(newDataDir, 'dir')
            mkdir(newDataDir);
        end
        
        videoList = dir(fullfile(dataStoreDir, dataFolderName, '*.avi'));
        labelList = dir(fullfile(dataStoreDir, dataFolderName, '*.mat'));
        
        videoList = natsortfiles({videoList.name});
        labelList = natsortfiles({labelList.name});
        
        for j = 1:size(videoList, 2)
            
            vid = VideoReader(fullfile(dataStoreDir, dataFolderName, videoList{1, j}));
            vidName = erase(convertCharsToStrings(vid.Name), ".avi");
            frameRate = vid.FrameRate;
            numFrames = vid.NumFrames;
            vidWidth = vid.Width;
            vidHeight = vid.Height;
            
            if (j > size(labelList, 2))
                break
            end
            
            labels = load(fullfile(dataStoreDir, dataFolderName, labelList{1, j}));
            imageName = convertCharsToStrings(labels.gTruth.LabelDefinitions.Name{1});
            fileNameToStore = fullfile(newDataDir);
            
            for k = 1:numFrames
                
                if (k > height(labels.gTruth.LabelData)) 
                  break
                end
                
                fileID = fopen(textFilename, "w");
                
                for numLabels = 1 : size(labels.gTruth.LabelDefinitions, 1)
                    
                    labelNames = labels.gTruth.LabelDefinitions.Name;
                    
                    labelName = labelNames{numLabels};
             
                    boundingBoxes = labels.gTruth.LabelData{k, labelName};
                    
                    frame = read(vid, k);
                    imgFilename = fullfile(fileNameToStore, strcat(vidName, "frame", num2str(k), "_", "img.jpg"));
                    imwrite(frame, imgFilename);
                    
                    textFilename = fullfile(fileNameToStore, strcat(vidName, "frame", num2str(k), "_", "img.txt"));
                    
                    boundingBoxes = boundingBoxes{1, 1};
                    
                    for z = 1:size(boundingBoxes, 1)
                        
                            currentBoundingBox = boundingBoxes(z, :);
                            
                            if isempty(currentBoundingBox)
                               continue   
                            end
                       
                            if strcmp(labelName, "Red_Buoy")
                                label = "1";
                                redBuoyCount = redBuoyCount+1;
                            elseif (strcmp(labelName, "Gate"))
                                label = "2";
                                gateCount = gateCount+1;
                            elseif (strcmp(labelName, "Torpedo"))
                                label = "3";
                                torpedoCount = torpedoCount+1;
                            elseif (strcmp(labelName, "Bin"))
                                label = "4";
                                binCount = binCount+1;
                            elseif (strcmp(labelName, "Green_Buoy"))
                                label = "5";
                                greenBuoyCount = greenBuoyCount+1; 
                            elseif (strcmp(labelName, "Yellow_Buoy"))
                                label = "6";
                                yellowBuoyCount = yellowBuoyCount+1;                                 
                            end
                               
                            xLeftCorner = currentBoundingBox(1);
                            yLeftCorner = currentBoundingBox(2);
                            bBoxWidth = currentBoundingBox(3);
                            bBoxHeight = currentBoundingBox(4);
                            
                            xCenterRatio = (xLeftCorner + (bBoxWidth/2))/vidWidth;
                            yCenterRatio = (yLeftCorner + (bBoxHeight/2))/vidHeight;
                            bBoxWidthRatio = bBoxWidth/vidWidth;
                            bBoxHeightRatio = bBoxHeight/vidHeight;
                
                            dataString = strcat(label," ", num2str(xCenterRatio), " ", ...
                                num2str(yCenterRatio), " ", num2str(bBoxWidthRatio), " ", ...
                                num2str(bBoxHeightRatio), "\n");
                            
                            fprintf(fileID, dataString);
                            
                    end
                    
                end
                
                fclose(fileID);
                 
            end  
        end
    end
end
redBuoyCount, gateCount, torpedoCount, binCount, greenBuoyCount, yellowBuoyCount
