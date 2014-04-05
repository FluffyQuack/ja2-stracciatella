#ifdef WITH_UNITTESTS
#include "gtest/gtest.h"

#include "sgp/FileMan.h"

#include "DefaultContentManager.h"
#include "DefaultContentManagerUT.h"

#define TMPDIR "temp"

#define PS PATH_SEPARATOR_STR

TEST(TempFiles, createFile)
{
  DefaultContentManager * cm = createDefaultCMForTesting();
  EraseDirectory(TMPDIR);
  FileMan::createDir(TMPDIR);

  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
  }

  std::vector<std::string> results = FindFilesInDir(TMPDIR, ".txt", false, false);
  ASSERT_EQ(results.size(), 1);
  EXPECT_STREQ(results[0].c_str(), TMPDIR PS "foo.txt");

  EraseDirectory(TMPDIR);
  delete cm;
}

TEST(TempFiles, writeToFile)
{
  DefaultContentManager * cm = createDefaultCMForTesting();
  EraseDirectory(TMPDIR);
  FileMan::createDir(TMPDIR);

  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
    FileWrite(file, "hello", 5);
  }

  // open for writing, but don't truncate
  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", false));
    ASSERT_EQ(FileGetSize(file), 5);
  }

  // open with truncate and check that it is empty
  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
    ASSERT_EQ(FileGetSize(file), 0);
  }

  // // void FileRead(SGPFile* const f, void* const pDest, size_t const uiBytesToRead)

  EraseDirectory(TMPDIR);
  delete cm;
}

TEST(TempFiles, writeAndRead)
{
  DefaultContentManager * cm = createDefaultCMForTesting();
  EraseDirectory(TMPDIR);
  FileMan::createDir(TMPDIR);

  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
    FileWrite(file, "hello", 5);
  }

  {
    char buf[10];
    AutoSGPFile file(cm->openTempFileForReading("foo.txt"));
    FileRead(file, buf, 5);
    buf[5] = 0;
    ASSERT_STREQ(buf, "hello");
  }

  EraseDirectory(TMPDIR);
  delete cm;
}

TEST(TempFiles, append)
{
  DefaultContentManager * cm = createDefaultCMForTesting();
  EraseDirectory(TMPDIR);
  FileMan::createDir(TMPDIR);

  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
    FileWrite(file, "hello", 5);
  }

  {
    AutoSGPFile file(cm->openTempFileForAppend("foo.txt"));
    FileWrite(file, "hello", 5);
  }

  {
    AutoSGPFile file(cm->openTempFileForReading("foo.txt"));
    ASSERT_EQ(FileGetSize(file), 10);
  }

  EraseDirectory(TMPDIR);
  delete cm;
}

TEST(TempFiles, deleteFile)
{
  DefaultContentManager * cm = createDefaultCMForTesting();
  EraseDirectory(TMPDIR);
  FileMan::createDir(TMPDIR);

  {
    AutoSGPFile file(cm->openTempFileForWriting("foo.txt", true));
  }

  std::vector<std::string> results = FindFilesInDir(TMPDIR, ".txt", false, false);
  ASSERT_EQ(results.size(), 1);

  cm->deleteTempFile("foo.txt");

  results = FindFilesInDir(TMPDIR, ".txt", false, false);
  ASSERT_EQ(results.size(), 0);

  EraseDirectory(TMPDIR);
  delete cm;
}

#endif
